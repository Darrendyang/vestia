package com.aishop.recognition;

import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

import javax.imageio.ImageIO;
import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;

@Component
public class BaselineRecognitionProvider {
    public Result recognize(Resource resource) throws IOException {
        if (resource == null) {
            return new Result(null, null);
        }
        try (InputStream inputStream = resource.getInputStream()) {
            BufferedImage image = ImageIO.read(inputStream);
            if (image == null) {
                throw new IOException("Unsupported image");
            }
            int stepX = Math.max(1, image.getWidth() / 64);
            int stepY = Math.max(1, image.getHeight() / 64);
            long red = 0;
            long green = 0;
            long blue = 0;
            long samples = 0;
            for (int x = 0; x < image.getWidth(); x += stepX) {
                for (int y = 0; y < image.getHeight(); y += stepY) {
                    Color color = new Color(image.getRGB(x, y), true);
                    if (color.getAlpha() < 128) {
                        continue;
                    }
                    red += color.getRed();
                    green += color.getGreen();
                    blue += color.getBlue();
                    samples++;
                }
            }
            if (samples == 0) {
                return new Result(null, null);
            }
            float[] hsb = Color.RGBtoHSB((int) (red / samples), (int) (green / samples), (int) (blue / samples), null);
            return new Result(colorName(hsb), 0.45);
        }
    }

    private String colorName(float[] hsb) {
        float hue = hsb[0] * 360;
        float saturation = hsb[1];
        float brightness = hsb[2];
        if (brightness < 0.16) return "BLACK";
        if (saturation < 0.12 && brightness > 0.9) return "WHITE";
        if (saturation < 0.16) return "GRAY";
        if (hue < 15 || hue >= 345) return "RED";
        if (hue < 45) return brightness < 0.6 ? "BROWN" : "ORANGE";
        if (hue < 70) return "YELLOW";
        if (hue < 170) return "GREEN";
        if (hue < 260) return "BLUE";
        if (hue < 290) return "PURPLE";
        return "PINK";
    }

    public record Result(String primaryColor, Double confidence) {
    }
}
