# Zude Tools

## A tool for assisting in podcast post-production. Made with love in Godot.

### Planned Release Features:
- [x] View all projects in a resizable gallery display with thumbnail previews.
	- [x] Automatically load last known directory for ease of use.
- [x] Create custom folder structure for new projects using a tree UI in the settings.
	- [/] Save and load folder structure presets.
		- (currently implemented in code only)
- [x] View a hero panel of relevant info for any focused/selected item.
	- [x] Preview the selected file. Currently only supports images and video. Video implementation is not great.
	- [x] Quickly open the selected file's location by clicking its name.
	- [x] Create a list of Photoshop and Krita template files in the settings menu.
	- [x] Generate template files for any selected file thru a "Templates" dropdown menu in the hero panel.
		- Makes a copy of the template next to the selected file.
		- Overwrites the copied template name with the selected file's name.
- [/] View a panel of tabs, each tab displaying the file contents of a sub-directory of the focused project.
	- This will soon be converted to a more traditional asset browser setup using a folder tree and a file panel.
	- Text editing support coming soon.
- [x] Basic theme customization.

### Long Term Features:
- [ ] Asynchronous loading and freeing of files.
- [ ] Assign naming styles to files based on a list of user-created templates.
- [ ] Resolve conflicts when converting to new folder rules though a graph UI.
- [ ] Create timestamp sheets for video editors for video files.

### QoL Ideas
- [ ] Shift-click to quickly select all files of the same file extension, making applying naming styles faster.
- [ ] Filter item display order based on name or date.
