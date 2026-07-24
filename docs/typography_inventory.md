# Typography Inventory

*Extracted directly from React Native Source via Regex extraction.*

## 1. Font Weights
The app utilizes a varied typographic scale with the following weights:
- Light: `300` (Used mostly for subtitles/captions)
- Normal: Implicitly `400`
- Medium: `500`
- Semi-Bold: `600`
- Bold: `700` (also specified as `bold`)
- Extra-Bold: `800`
- Black: `900` (Used for AppName on Splash Screen)

## 2. Font Sizes
To maintain pixel-perfection, the following exact sizes must be mapped in Flutter:
- Micro: 8, 9, 10, 11
- Caption/Small: 12, 13
- Body: 14, 15, 16
- Subheading: 17, 18, 20
- Heading: 22, 24, 26, 28, 30
- Display/Giant: 36, 40, 48, 52, 56, 72

*Note: The exact font family was not explicitly extracted globally, indicating standard system fonts (Roboto/San Francisco) are used, but will be verified.*
