# Zude Tools

## A tool for assisting in podcast post-production. Made with love in Godot.

### Planned Features:
- [x] Open a production directory of project folders.
	[x] Automatically load last known directory for ease of use.
	[ ] Filter display order based on name or date.
	[ ] Filter display order based directory or naming conflicts.
- [x] View all projects in a resizable gallery display with thumbnail previews.
	[ ] Load a buffer of projects on startup instead of all of them.
	[ ] Only search the pre-configured thumbnail and hero video sub-directories on startup instead of loading all project files.
- [x] View a "hero panel" of relevant info for the focused project.
- [/] View a panel of tabs, each tab displaying the file contents of a sub-directory of the focused project.
	- [ ] Display text files as cards.
	- [x] Display image files as cards.
	- [x] Display video files as cards.
	- [x] Display template files as cards. (.psd, .kra, etc.)
	- [x] Resize file previews with a slider.
	- [x] Reuse tab instances.
	- [ ] Asynchronous loading and freeing of files.
- [x] Create desired directory structure for projects.
- [ ] Generate template files for any other file through a context menu using the file name and any pre-configured tags.
- [ ] Enforce desired naming conventions for files based on their project sub-directory.
- [ ] Resolve naming conflicts when enforcing file or folder rules.
- [ ] Create timestamp sheets for video editors for video files.
- [/] Settings customization.
	- [x] Assign a default thumbnail preview in the event the a project directory does not have a suitable candidate.
	- [x] Create a list of template files that can be generated based on any existing image, video, or text file.
		- [x] Restrict the generation of template files to only generate based on specified file extensions.
	- [X] Create a desired directory structure that can be enforced upon projects.
	- [ ] Assign the production a top level naming convention, or specify per project sub-directory based on pre-configured settings.
	- [x] Basic theme customization.
