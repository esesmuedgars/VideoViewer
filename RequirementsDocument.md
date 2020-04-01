## iPhone Photography School iOS Developer Test Assignment

### Task

Create an application from scratch where users can pick a video from a list and watch it in the details view. Also they have to be able to download and watch the video when there's no internet connection.

Please make sure you are following all guidelines before submitting your solution. Only a 100% working and efficient solution will make us consider this test passed.

### Requirements

Video list screen:
- Display title “_Videos_”;
- Display a list of videos;
- Display a thumbnail image and name for each video;
- Implemented pull-to-refresh functionality to refresh the list of videos;
- List of videos has to be fetched, from URL or cache, on application launch.

Video details screen:
- Display video player;
- Display a “_Download video_” button to start download for offline viewing;
- Display a “_Cancel download_” and progress bar when video is downloading;
- Display video title and description.

API endpoint: https://iphonephotographyschool.com/test-api/videos.

### Design

Design has to closely match the following screenshots and look good in both, light and dark modes.

<img alt="Video list screenshot" src="https://github.com/esesmuedgars/VideoViewer/blob/assets/video_list_screen.png" width="50%" /><img alt="Video details screenshot" src="https://github.com/esesmuedgars/VideoViewer/blob/assets/video_details_screen.png" width="50%" />

### What we are looking for:

- Develop the application using:
  - Xcode;
  - CocoaPods;
  - SwiftUI;
  - Combine.
- Try to use as few 3<sup>rd</sup>-party libraries as possible. It's fine to use CocoaPods for pull-to-refresh and Alamofire;
- Application has to work offline with cached video list;
- Write automated tests using framework of your choice. Tests have to be meaningful and comprehensive and cover all important functionality of the application. 

### Submission

Project should be stored in your own private GitHub repository with access rights given to user [@JPurinsh](https://github.com/JPurinsh). Repository should contain commits representing different stages of progress.
In case you don't have a GitHub account, .zip with .git folder included also works.

Please send us an email to [careers@iphonephotographyschool.com](mailto:careers@iphonephotographyschool.com?subject=iOS%20Developer) with the link to your GitHub repository once you've done the assignment.

Make sure that all tests pass before submitting.
