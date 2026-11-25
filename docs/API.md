# Vestia API Guide

Base URL: `/api/v1`

Development requests may include `X-User-Id: 00000000-0000-0000-0000-000000000001`. This is a development convenience, not production authentication.

## Create a wardrobe item

`POST /wardrobe/items` with `multipart/form-data`.

Fields:

- `file`: optional JPEG, PNG, or WebP image, up to 10 MB.
- `category`: `TOP`, `BOTTOM`, `DRESS`, `OUTERWEAR`, `SHOES`, `ACCESSORY`, or `UNKNOWN`.
- `primaryColor`, `brand`, `material`, `styleTags`: optional attributes.
- `source`: `PHOTO`, `SCREENSHOT`, `MANUAL`, or `DEMO`.

Returns HTTP 202 with the item and a `taskId`. Poll `GET /tasks/{taskId}` until recognition succeeds or fails. The baseline only estimates dominant color; it does not claim multimodal category recognition.

`POST /wardrobe/items/{id}/image` replaces the image of an existing item and starts a new recognition task. It preserves wear history and requires the same user ownership checks as the original upload.

## Generate outfits

```http
POST /outfits/recommendations
Content-Type: application/json

{
  "occasion": "COMMUTE",
  "weather": "15°C 小雨"
}
```

The response contains up to three persisted outfits. It excludes unavailable items, recently worn items, and rain-unsafe canvas shoes. If the wardrobe cannot produce three valid combinations, the response is explicitly marked as degraded.

## Adopt an outfit

```http
POST /outfits/recommendations/{id}/feedback
Content-Type: application/json

{
  "feedback": "ADOPTED"
}
```

Adoption increments each item's wear count once. Repeating adoption on the same recommendation does not increment it again.

## Style DNA

`GET /style-profile/current` returns the rule-versioned profile, style/color distributions, category coverage, outfit potential, health score, and insights.

## Analyze a potential purchase

```http
POST /shopping/analyses
Content-Type: application/json

{
  "category": "OUTERWEAR",
  "primaryColor": "BLACK",
  "brand": "Example coat",
  "styleTags": "COMMUTE,MINIMAL"
}
```

The analysis estimates new base outfits and lists compatible wardrobe items. It does not claim live pricing, stock, sizing, or marketplace coverage. `GET /shopping/analyses` returns the current user's analysis history.

## Automatic weather

`GET /weather/current?latitude={lat}&longitude={lon}` returns current temperature, precipitation, weather code, description, source, and observation time from Open-Meteo. The Flutter client requests location permission and clearly labels its Shanghai fallback when permission or location services are unavailable.

## Providers and try-on

`GET /providers` exposes real provider availability and configuration modes.

`POST /tryon-jobs` requires explicit image-processing consent. The current repository does not upload photos or create a fabricated result when no approved provider adapter is configured. A configured custom URL alone is not enough; an adapter contract and quality/privacy review are required.

## Errors

Errors use a common structure:

```json
{
  "code": "INSUFFICIENT_WARDROBE",
  "message": "Human-readable detail",
  "retryable": false,
  "requestId": "req-id",
  "timestamp": "2026-05-01T00:00:00Z"
}
```
