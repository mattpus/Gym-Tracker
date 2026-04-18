# Running the app locally

This repo uses a **generated Xcode project** approach instead of checking in a hand-maintained `.xcodeproj`.

## Prerequisite

Install XcodeGen if you do not already have it:

```bash
brew install xcodegen
```

## Generate the project

From the repo root:

```bash
xcodegen generate
```

This will create:

- `GymTracker.xcodeproj`

## Open and run

```bash
open GymTracker.xcodeproj
```

In Xcode:

1. Select the **GymTrackerApp** scheme
2. Choose an iPhone simulator, for example **iPhone 16**
3. Press **Run**

## Run UI tests

After generating the project, you should be able to run:

```bash
xcodebuild test \
  -project GymTracker.xcodeproj \
  -scheme GymTrackerApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Or run the **GymTrackerUITests** from Xcode.

## Notes

- The generated project pulls app logic from `App/`
- Domain/data modules are consumed from the local Swift package in `Package.swift`
- If you change target structure, update `project.yml` and regenerate the project
