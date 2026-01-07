# Friendly Score - Complete User Guide

**For Product Owners and Stakeholders**

---

## 📱 Application Overview

Friendly Score is a sports timing and performance tracking application designed for equestrian sports and show jumping events. The application connects to specialized Bluetooth hardware (ESP32 device) to precisely measure race times, track rider performance, and generate detailed reports.

---

## 🚀 Getting Started

### First Launch

When you open the application, you'll see:

- **App Name**: "Friendly Score" displayed at the top
- A clean, modern interface with a light background
- Easy-to-read text using professional fonts

---

## 🔐 Security & Login

### PIN Login Screen

- **What You See**: A numeric keypad (like a phone) with numbers 0-9
- **What You Do**: Enter your 4-digit PIN code to access the application
- **Security**: Four dots appear as you type to protect your PIN
- **Buttons Available**:
  - Number buttons (0-9) to enter your PIN
  - Delete button (backspace icon) to correct mistakes
- **What Happens**: After entering the correct PIN, you proceed to set your event location

---

## 📍 Event Location Setup

### Location Screen

- **Purpose**: Record where the event is taking place
- **What You Enter**:
  - **Location Name**: E.g., "Springfield Arena", "Country Club Grounds"
  - **Address**: Full address of the venue
- **What You See**:
  - Two input fields with location icon
  - Large "CONTINUE" button at the bottom
- **What Happens**: Your location is saved and you move to mode selection

---

## 🎯 Main Menu - Mode Selection

### Three Main Modes Available:

#### 1. **Mounted Sports Mode** (Green)

- **Icon**: Hourglass symbol
- **Purpose**: For equestrian and mounted sports events
- **Description**: "Equestrian and mounted events"
- **Color Theme**: Green
- **Use When**: Timing horse riding events with start/finish or start/verify/finish points

#### 2. **Show Jumping Mode** (Blue)

- **Icon**: Paper plane symbol
- **Purpose**: Time trials and competition modes for show jumping
- **Description**: "Time trials and competition modes"
- **Color Theme**: Blue
- **Use When**: Running show jumping competitions with countdown challenges
- **Sub-modes available**: Top Score and Normal Jumping

#### 3. **Reports & Analytics** (Purple)

- **Icon**: Chart/graph symbol
- **Purpose**: View performance data and generate reports
- **Description**: "Performance insights and data analysis"
- **Color Theme**: Purple
- **Use When**: Reviewing past performances, checking statistics, analyzing trends

---

## 🏇 Mounted Sports Mode - Complete Flow

### Step 1: Race Type Selection

After selecting Mounted Sports, you choose the race format:

#### Option A: Start → Finish

- **What It Means**: Simple two-point timing
- **How It Works**: Timer starts when rider crosses start line, stops at finish line
- **Icon**: Flag with arrow
- **Use Case**: Basic time trials

#### Option B: Start → Verify → Finish

- **What It Means**: Three-point timing with verification checkpoint
- **How It Works**: Timer starts at start line, records verify time at checkpoint, stops at finish line
- **Icon**: Flag with checkmark
- **Use Case**: Complex courses with mandatory checkpoints

### Step 2: Rider Details Entry

- **What You Enter**:
  - **Rider Name** (optional): The person competing
  - **Rider Number** (optional): Bib or registration number
- **Additional Options**:
  - **Take Photo**: Camera button to photograph the rider
  - **Select from Gallery**: Image button to choose existing photo
- **What You See**: Photo preview if image was added
- **Button**: "CONTINUE" when ready

### Step 3: Waiting for Race to Start

- **What You See**:

  - Bluetooth connection status
    - Green checkmark with "Connected" if hardware is ready
    - Spinner with "Connecting to ESP32-BT-Client..." while connecting
  - Summary of race details:
    - Rider name and number
    - Race type selected
    - "Timer: Starts from 0:00:00"
  - Large green circular button showing "READY" status
  - Message: "Waiting for start signal from hardware"

- **What Happens**:

  - **App waits for hardware**: The system is listening for the start signal
  - **Hardware detects start**: When the rider crosses the start line, the ESP32 device detects it
  - **Signal sent**: Hardware automatically sends start command to the app
  - **Race begins**: App receives signal and immediately starts the timer
  - **Automatic navigation**: You're taken to the active race screen

- **Important**: You do NOT press a button to start - the race starts automatically when hardware detects the rider at the start line

### Step 4: Active Race (In Progress)

- **What You See**:

  - **Large Timer Display**: Shows elapsed time in format HH:MM:SS
  - **Timer starts at**: 0:00:00
  - **Timer counts**: Upward (0 → increasing)
  - **Color Changes**:
    - Green (0-30 seconds)
    - Gradually transitions to orange (30-60 seconds)
    - Orange to red (60+ seconds)
  - **Pulsing Glow Effect**: Animated glow around the timer
  - **Rider Information**: Name and number displayed at top
  - **Status**: "Race in Progress"

- **Buttons Available**:

  - **PAUSE** button (yellow): Temporarily stop the timer
  - **STOP & RECORD** button (red): End the race and save time

- **Pause Functionality**:

  - When paused, timer freezes
  - Button changes to "RESUME"
  - Yellow warning: "Race is paused"
  - Can resume to continue timing

- **Hardware Communication**:
  - System waits for finish signal from hardware
  - When finish beacon is detected, race automatically completes
  - Alternative: Manual stop with button

### Step 5: Race Results

- **What You See**:

  - **Large Time Display**: Final elapsed time
  - **Success/Failure Indicator**:
    - Green background with trophy icon = Success
    - Red background = Stopped/Failed
  - **Race Details Card**:
    - Rider name (if provided)
    - Rider number (if provided)
    - Event location and address
    - Sport mode name
  - **Photo**: Rider photo if one was taken

- **Data Auto-Save**:

  - Results are **automatically saved** to database
  - Green popup appears: "Data Saved Successfully!"
  - Message confirms: "Your race data has been automatically saved"
  - No manual save needed - you won't lose data

- **Buttons Available**:
  - **NEW RACE** (blue): Start another race with same settings
  - **CHANGE RIDER** (purple): New race with different rider
  - **BACK TO MODE** (grey): Return to mode selection

---

## 🎪 Show Jumping Mode - Complete Flow

### Step 1: Jump Type Selection

After selecting Show Jumping, you choose:

#### Option A: Top Score Mode

- **Icon**: Trophy symbol
- **Color**: Orange
- **Description**: "Countdown challenge mode"
- **What It Means**: Rider races against a countdown timer
- **Special Feature**: Two-phase countdown system

#### Option B: Normal Jumping Mode

- **Icon**: Target symbol
- **Color**: Teal/Blue
- **Description**: "Standard jumping mode"
- **What It Means**: Traditional timing from start to finish

### For Top Score Mode:

#### Step 2: Set Countdown Time

- **What You See**: Three spinning wheels for time selection
  - **Hours Wheel**: 0-23 hours
  - **Minutes Wheel**: 0-59 minutes
  - **Seconds Wheel**: 0-59 seconds
- **How It Works**: Scroll each wheel to set desired time
- **Visual**:
  - Large digital display shows selected time (00:00:00)
  - Max time calculation displayed (doubles your set time)
  - Example: Set 15 seconds → Max time shows 30 seconds
- **Requirement**: Must set time greater than 0
- **Button**: "SET TIMER" when ready

#### Step 3: Confirm Time Settings

- **What You See**:
  - **Set Time**: The countdown time you chose
  - **Max Time**: Double your set time (safety limit)
  - Example display: "00:00:15 → 00:00:30"
- **What You Enter**: Same as Mounted Sports
  - Rider name (optional)
  - Rider number (optional)
  - Photo option
- **Buttons**:
  - "CONFIRM" to proceed
  - "BACK" to change time settings

#### Step 4: Waiting for Race to Start

- **What You See**:

  - Bluetooth connection status (connecting/connected)
  - Summary of race details:
    - Rider name and number
    - Time Set: Your countdown time
    - Max Time: The limit
  - Large green "READY" indicator
  - Status message: "Waiting for start signal from hardware"

- **What Happens**:
  - App is ready and listening for hardware signal
  - Hardware detects when rider crosses start line
  - Start signal sent automatically from ESP32 device
  - Timer begins immediately upon receiving signal

#### Step 5: Active Race - Top Score Countdown

**🎯 This is the special Top Score timing logic:**

**Phase 1: Countdown Phase**

- **Timer starts at**: Your set time (e.g., 30 seconds)
- **Timer counts**: Downward (30 → 0)
- **Display**: Shows decreasing time
- **Color**: Green throughout countdown
- **Goal**: Complete the course before timer reaches zero
- **What Happens at Zero**: Automatically switches to Phase 2

**Phase 2: Count-Up Phase**

- **Timer starts at**: 0 seconds
- **Timer counts**: Upward (0 → max time)
- **Display**: Shows increasing time
- **Color Changes**:
  - Orange (0-30 seconds over)
  - Gradually transitions to red (30+ seconds over)
- **Pulsing Effect**: Timer has animated glow
- **Meaning**: Shows how much time over the target

**Example Timeline**:

```
Set Time: 30 seconds
Max Time: 60 seconds

Phase 1 (Green):
30 → 29 → 28 → ... → 3 → 2 → 1 → 0

Phase 2 (Orange → Red):
0 → 1 → 2 → ... → 28 → 29 → 30 (max)
```

**Buttons During Race**:

- **PAUSE**: Freeze timer at current point
- **FINISH**: Mark successful completion
- **DISQUALIFY**: End race as failed

**Success Criteria**:

- ✅ Finish during Phase 1 (before countdown reaches 0) = Great!
- ⚠️ Finish during Phase 2 (after 0, within max time) = Overtime
- ❌ Exceed max time = Failure

### For Normal Jumping Mode:

#### Step 2: Set Time Limits

- **Same Wheel Interface**: Select hours, minutes, seconds
- **Set Time**: The target time to beat
- **Max Time**: Maximum allowed time (automatically doubles)
- **Button**: "SET TIMER"

#### Step 3-4: Same as Top Score (Confirm & Ready screens)

#### Step 5: Active Race - Normal Mode Timing

**Timer Behavior**:

- **Timer starts at**: 0:00:00
- **Timer counts**: Upward (0 → max time)
- **Color Transitions**:
  - **Green**: 0 to 30 seconds
  - **Orange**: 30 to 60 seconds (gradual transition from green)
  - **Red**: 60+ seconds (gradual transition from orange)
- **Display**: Clean, large time display with pulsing glow

**Buttons Available**:

- **PAUSE/RESUME**: Control timer
- **FINISH**: Complete successfully
- **DISQUALIFY**: Mark as failed

**Success Logic**:

- ✅ Finish under set time = Success
- ⚠️ Finish between set and max time = Warning
- ❌ Exceed max time = Failure

#### Step 6: Race Results (Same for Both Modes)

- Shows final time
- Success/failure status
- All race details
- Auto-save confirmation
- Same navigation buttons

---

## 📊 Reports & Analytics Mode

### Main Reporting Dashboard

#### What You See:

- **Title**: "All Race Records"
- **Clean List View**: Simple row-by-row display of all race records
- **Newest First**: Latest races at the top, oldest at the bottom
- **Pull to Refresh**: Drag down to reload the latest data

#### Each Race Record Shows:

**Left Side**:

- **Rider Name**: Displays rider's name or "Rider name not available" if not set
- **Rider Number**: Shows as a blue badge (e.g., "#42") if available
- **Sport Mode**: The type of race (Mounted Sports, Show Jumping, etc.)
- **Date & Time**: When the race took place

**Right Side**:

- **Elapsed Time**: Large, easy-to-read time display (HH:MM:SS:MS format)
- **Status Badge**: Color-coded status indicator
  - 🟢 **FINISHED** (Green): Successfully completed
  - 🟠 **STOPPED** (Orange): Race was manually stopped
  - 🔴 **DISQUALIFIED** (Red): Failed/disqualified

#### Viewing Full Details:

- **Tap Any Record**: Click on any race row to view complete details
- **Detailed View Shows**:
  - **Status Header**: Large status indicator with race time
  - **Rider Information**:
    - Name and number
    - Photo (if available)
  - **Performance Details**:
    - Elapsed time
    - Target time (if applicable)
    - Status details
  - **Event Information**:
    - Sport mode
    - Date and time
    - Location name
    - Venue address
  - **Hardware Information**:
    - Device used (ESP32-BT-Client)
    - Connection status

#### Navigation:

- **Back Button**: Return to mode selection menu
- **Pull to Refresh**: Update with latest race data
- **Tap Record**: View full details
- **Back from Details**: Return to list

#### Features:

✅ **All Records Displayed**: No pagination - every race record is shown
✅ **Chronological Order**: Latest races always at the top
✅ **Visual Status**: Quick color-coded status identification
✅ **Photo Support**: View rider photos in detail view
✅ **Complete Information**: All race data accessible with one tap
✅ **Smooth Animations**: Clean transitions between screens
✅ **Offline Access**: All data stored locally

---

## 🎨 User Interface Experience

### Visual Design:

- **Color Scheme**: Clean white backgrounds with colorful accents
- **Font**: Modern, professional Inter font family
- **Readability**: Large, clear text suitable for outdoor/arena use
- **Icons**: Intuitive Font Awesome icons throughout

### Animations:

- **Smooth Transitions**: Screens fade and slide elegantly
- **Button Press Effects**: Haptic feedback and visual response
- **Timer Glow**: Pulsing effect keeps attention on timer
- **Loading States**: Smooth spinners when processing

### Responsive Elements:

- **Large Touch Targets**: Easy to press buttons even with gloves
- **Color-Coded Feedback**:
  - Green = Success/Good/Go
  - Yellow/Orange = Warning/Caution
  - Red = Stop/Error/Failure
  - Blue = Information/Primary action
  - Purple = Analytics/Reports

### Status Indicators:

- **Bluetooth Connection**:

  - Green checkmark = Connected
  - Red X = Disconnected
  - Spinner = Connecting

- **Race Status**:
  - "Ready to Start"
  - "Race in Progress"
  - "Paused"
  - "Completed"
  - "Stopped"

---

## 🔌 Bluetooth Hardware Integration

### Connection Process:

1. **Automatic**: App tries to connect to ESP32 device
2. **Success Screen**: Green confirmation when connected
3. **Failure Screen**: Red error if connection fails with retry option

### Commands Sent to Hardware:

- **Pause Command**: Temporarily stops timing
- **Resume Command**: Continues after pause
- **Finish Command**: Completes race successfully (when using manual finish button)

### Signals Received from Hardware:

**Critical: Race Start Process**

- **NO manual start button** - Races do NOT start from the app
- **Hardware-triggered start**: The ESP32 device has sensors/beacons at the start line
- **Automatic detection**: When rider crosses start line, hardware detects it
- **Start signal sent**: Hardware sends start command to app automatically
- **App responds**: Timer begins immediately upon receiving hardware signal
- **This ensures**: Precise timing from the exact moment rider crosses start line

### Other Hardware Signals:

- **Start Beacon**: Confirms race started
- **Verify Beacon**: Checkpoint reached (Mounted Sports)
- **Finish Beacon**: Race completed
- **Status Updates**: Connection health

---

## 💾 Data Management

### Automatic Saving:

- **When**: Immediately after race completion
- **What's Saved**:
  - Final race time
  - Rider name and number
  - Photo (if taken)
  - Event location
  - Sport mode and race type
  - Success/failure status
  - Date and timestamp
  - Device information

### Data Persistence:

- **Storage**: Local database on device
- **No Loss**: Data saved even if app closes
- **Access**: Available in Reports section anytime

### No Manual Save Needed:

- Green popup confirms auto-save
- Can't lose data by accident
- No "unsaved changes" warnings

---

## 🎯 Key Functionalities Summary

### Core Features:

✅ PIN-protected access
✅ Event location tracking
✅ Two sport modes (Mounted, Show Jumping)
✅ Multiple race types per mode
✅ Customizable time settings
✅ Rider details capture
✅ Photo documentation
✅ Real-time race timing
✅ Pause/resume capability
✅ Manual and automatic finish detection
✅ Automatic data saving
✅ Comprehensive reporting
✅ Performance analytics
✅ Historical data tracking
✅ Bluetooth hardware integration

### Workflow Phases:

1. **Authentication** → PIN login
2. **Setup** → Location entry
3. **Mode Selection** → Choose sport
4. **Race Configuration** → Type and time settings
5. **Rider Information** → Details entry
6. **Race Execution** → Timing and tracking
7. **Results Recording** → Auto-save
8. **Analysis** → Reports and insights

---

## 🎪 Example User Journeys

### Journey 1: Quick Show Jumping Top Score Race

1. Open app → Enter PIN (4567)
2. Enter location → "County Arena"
3. Select "Show Jumping" (blue)
4. Choose "Top Score" (orange trophy)
5. Set countdown → 0 hours, 0 minutes, 20 seconds
6. Confirm → Shows max time of 40 seconds
7. Enter rider → "Sarah Johnson", #42, take photo
8. Screen shows "READY - Waiting for start signal"
9. Rider crosses start line → Hardware detects and sends signal
10. Timer starts automatically: 20 → 19 → 18... (green)
11. Rider finishes at 18 seconds (Phase 1) = SUCCESS!
12. Results show green trophy with 18 second time
13. Data auto-saves
14. Press "NEW RACE" for next rider

### Journey 2: Mounted Sports with Checkpoint

1. Open app → Enter PIN
2. Location already saved from before
3. Select "Mounted Sports" (green)
4. Choose "Start → Verify → Finish"
5. Enter rider → "Mike Torres", #15
6. App shows "READY" - waiting for hardware start signal
7. Rider crosses start line → Hardware sends start command
8. Timer counts up automatically from 0:00:00 (green)
9. At 45 seconds, turns orange
10. Hardware sends finish signal at 1:23
11. Results display success
12. Auto-saves with all details
13. Press "CHANGE RIDER" for different contestant

### Journey 3: Reviewing Performance

1. From main menu, select "Reports & Analytics" (purple)
2. See complete list of all race records
3. Latest races appear at the top
4. Scan through the list - each shows rider name, time, and status
5. Notice Sarah Johnson's race with green "FINISHED" badge
6. Tap on Sarah's record to view details
7. See her photo, complete race information, and all performance metrics
8. Swipe back to list
9. Pull down to refresh and see any new races
10. Return to main menu to run more races

---

## ❓ What's Missing or Could Be Added?

### Potential Enhancements to Discuss:

**Data Export**:

- PDF report generation?
- CSV export for spreadsheet analysis?
- Email/share race results?

**Multi-User Support**:

- Different PIN codes for different users?
- User profiles and preferences?

**Advanced Timing**:

- Split times at multiple checkpoints?
- Lap timing for multi-lap races?

**Enhanced Photos**:

- Multiple photos per race?
- Video recording capability?

**Competition Features**:

- Head-to-head comparisons?
- Leaderboards?
- Scoring systems?

**Offline Mode**:

- What happens without internet?
- Sync when connection restored?

**Customization**:

- Adjustable color themes?
- Custom race types?
- Configurable time ranges?

**Hardware**:

- Support for multiple devices?
- Backup timing device option?

**Notifications**:

- Race reminders?
- Achievement alerts?

---

## 📱 Technical Requirements (Minimal Detail)

### Device Needs:

- Smartphone or tablet (Android/iOS)
- Bluetooth capability
- Camera (for photos)
- Internet (for initial setup)

### Hardware:

- ESP32 Bluetooth timing device
- Charged and powered on
- Within range of smartphone

---

## 🆘 Common Questions

**Q: What if I forget my PIN?**
A: Contact administrator for PIN reset.

**Q: Can I edit race results after saving?**
A: Currently auto-saved data is permanent. Discuss if edit capability needed.

**Q: How many races can I store?**
A: Unlimited - limited only by device storage.

**Q: Can multiple people use the app?**
A: Yes, but currently shares same PIN. Discuss multi-user needs.

**Q: What happens if Bluetooth disconnects mid-race?**
A: Timer continues running, can finish manually with button.

**Q: Can I delete old races?**
A: Discuss if data deletion/archiving is needed.

**Q: Do I need internet for races?**
A: No - races work offline. Reports may need internet for advanced features.

---

## 📋 Summary Checklist

For each race, the system handles:

- ✅ Secure access
- ✅ Location tracking
- ✅ Mode selection
- ✅ Time configuration
- ✅ Rider documentation
- ✅ Accurate timing
- ✅ Status monitoring
- ✅ Result calculation
- ✅ Automatic data storage
- ✅ Performance reporting

---

**Document Version**: 1.0  
**Last Updated**: January 5, 2026  
**Prepared For**: Product Owner / Stakeholder Review  
**Purpose**: Requirements verification and feature discussion
