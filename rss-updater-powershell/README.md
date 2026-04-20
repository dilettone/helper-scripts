# RSS File Updater (Powershell)

I wrote this to save some hassle from manually updating my `feed.xml` (RSS feed file) every time I made a new blog post html file.

It takes a single input parameter - a path to a HTML file - and adds it as an item to the XML channel object, populating values based on HTML file attributes. It adds the basic RSS attributes - **title**, **description**, **link**, **guid** and **pubdate**.

There are probably some more improvements to be made, like making it scan a whole directory and rebuild the whole feed every time.

## Usage

Paste this script into the relevant folder.

Change the variables at the top of the script file, then run:
```ps
.\rss.updater.ps1 path\to\your\file.html
```