Erase all
#### define variables
spectrogram_maximum_frequency = 5000
f0min = 75
f0max = 1000
dynamic_range = 45
smooth = 50
picture_width = 6
osc_height = 2
spec_height = 5


#### form
form Create_pictures
    comment Select main folder (contains audio files within folders)
    sentence Main_folder
    comment Select folder to export PNG files
    sentence Pictures_folder
endform

#### script
    # create list of folders
    Create Strings as folder list... folder_list 'main_folder$'
    numberOfFolders = Get number of strings

    if numberOfFolders = 0
      exitScript: "No folders"
    endif

    for ifolder to numberOfFolders
      select Strings folder_list
      # create list of wavs
      folderName$ = Get string... ifolder
      Create Strings as file list... mywavlist 'main_folder$'/'folderName$'/*.wav
      numberOfFiles = Get number of strings
      if numberOfFiles = 0
        exitScript: "No files"
      endif

      # create list of files
      for ifile to numberOfFiles
        select Strings mywavlist
        fileName$ = Get string... ifile
          spaces = index(fileName$," ")
          if spaces <> 0
            exit "Filenames cannot have spaces"
          endif

        base0$ = fileName$ - ".wav"
        base$ = replace$ (base0$,".","_",0)
        title$ = replace$ (base$,"_"," ",0)
        Read from file... 'main_folder$'/'folderName$'/'fileName$'

        startTime = Get start time
        end = Get end time
        endTime = number(fixed$('end',4))
        x = ('startTime'+'endTime')/2
        midpoint = number(fixed$(x,4))

      # appearance
        Times
        Font size... 14
        Line width... 1
        Black

      # spectrogram
        select Sound 'base$'
        To Spectrogram... 0.005 'spectrogram_maximum_frequency' 0.002 20 Gaussian
        Viewport... 0 'picture_width' 'osc_height' 'spec_height'
        Paint... 0 0 0 0 100 yes dynamic_range 6 0 no
        One mark left... 0 yes yes no
        One mark left... spectrogram_maximum_frequency yes yes no


      # fundamental
        select Sound 'base$'
        To Pitch (ac)... 0.005 'f0min' 15 no 0.03 0.1 0.01 0.35 0.14 'f0max'
        Smooth... smooth
        select Pitch 'base$'
        #get median pitch
        y = Get quantile... 0 0 0.50 Hertz
        med_pitch = number(fixed$(y,2))

      # draw oscillogram
        Select outer viewport... 0 'picture_width' 0 'osc_height'
        Draw inner box
        One mark bottom... 0 yes yes no
        One mark bottom... 'endTime' yes yes no
        One mark bottom... 'midpoint' yes yes yes
        select Sound 'base$'
        Draw... 0 0 0 0 no curve
        Text top... yes 'title$'
        Text bottom... yes Time (sec)
        Select outer viewport... 0 'picture_width' 'osc_height' 'spec_height'

      # draw pitch
        Line width... 10
        White
        select Pitch 'base$'
        min = Get minimum... 0 0 Hertz parabolic
        max = Get maximum... 0 0 Hertz parabolic
        ymin = number(fixed$(min,2))
        ymax = number(fixed$(max,2))
        Draw... 0 0 'ymin' 'ymax' no

        Line width... 6
        Black
        Draw... 0 0 'ymin' 'ymax' no

      # draw spectrogram box
        Line width... 1
        Draw inner box
        One mark right... 'ymax' yes yes no
        One mark right... 'ymin' yes yes no
        One mark bottom... 'midpoint' no yes yes
        Text left... yes Frequency (Hz)
        Text right... yes F_0 (Hz)
        Axes: 0, 'endTime', ymin, ymax
        Text special... 'endTime' left 'med_pitch' top Times 10 "0" 'med_pitch'

      # saving
        Viewport... 0 'picture_width' 0 'spec_height'
        createFolder: pictures_folder$ + "/" + folderName$
        Save as 600-dpi PNG file: pictures_folder$ + "/" + folderName$ + "/" + base$ + ".png"
        Erase all

      # clean objects
        select all
        minus Strings mywavlist
        minus Strings folder_list
        Remove
      endfor
  endfor

  echo All files saved.
  selectObject: "Strings mywavlist"
  Remove
