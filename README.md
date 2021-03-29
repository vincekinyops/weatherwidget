### weatherwidget
A Weather widget based on current location

---

### Assumption
> This app is done in the assumption of **coaching a junior engineer** who just joined the team.
> Components and structure of the app are made to be simple as possible.
> Working features are written in the purpose of demonstration.
> No real production structure is being followed. Userdefaults are used for image transfer from main app to widget.
> I myself have learnt a lot by doing this app.

> The main app itself is written using UIKit and Storyboard/Xibs, while the widget is on SwiftUI Views.

---

### Setup 
> On Xcode, make sure the Target is set to MyWidgetExtension, that way you can be sure to
> be installing the Widget right away. The WeatherWidget target is the main app. Please dont be confused with the naming. 

### *Caveat\!!!*
This app runs smoothly mostly on iOS14, since Widget requires SwiftUI, and most of the functions pertaining to the app features run only on iOS14+.
Although most code can be rewritten to be compatible with iOS13.

Crashes occur when multiple widgets are shown and background image selected. This is due to Memory Leak issue, probably due to image size.
