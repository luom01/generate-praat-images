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
    comment Select folder to export PNG files
    sentence Pictures_folder
endform
#### script
base0$ = selected$ ("Sound")
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
  select Sound 'base0$'
  To Spectrogram... 0.005 'spectrogram_maximum_frequency' 0.002 20 Gaussian
  Viewport... 0 'picture_width' 'osc_height' 'spec_height'
  Paint... 0 0 0 0 100 yes dynamic_range 6 0 no
  One mark left... 0 yes yes no
  One mark left... spectrogram_maximum_frequency yes yes no


# fundamental
  select Sound 'base0$'
  base$ = replace$ (base0$,".","_",0)
  title$ = replace$ (base$,"_"," ",0)
  To Pitch (ac)... 0 'f0min' 15 no 0.03 0.1 0.01 0.35 0.14 'f0max'
  Smooth... smooth
  select Pitch 'base$'
  y = Get mean... 0 0 Hertz
  avg_pitch = number(fixed$(y,2))

#### drawing
# draw oscillogram
  Select outer viewport... 0 'picture_width' 0 'osc_height'
  Draw inner box
  #Marks bottom every... 1 0.1 no yes no
  #Marks bottom every... 1 0.2 yes yes no
  One mark bottom... 0 yes yes no
  One mark bottom... 'endTime' yes yes no
  One mark bottom... 'midpoint' yes yes yes
  select Sound 'base0$'
  Draw... 0 0 0 0 no curve
  Text top... yes 'title$'
  Text bottom... yes Time (sec)


# draw spectrogram and pitch
  Select outer viewport... 0 'picture_width' 'osc_height' 'spec_height'

  # draw pitch
    Line width... 10
    White
    select Pitch 'base$'
    Draw... 0 0 'f0min' 'f0max' no

    Line width... 6
    Black
    Draw... 0 0 'f0min' 'f0max' no

  # draw spectrogram box
    Line width... 1
    Draw inner box
    #Marks left every... 1 100 no yes no
    #Marks left every... 1 1000 yes yes no
    #Marks right every... 1 50 no yes no
    #Marks right every...1 100 yes yes no
    One mark right... 'f0max' yes yes no
    One mark right... 'f0min' yes yes no
    One mark bottom... 'midpoint' no yes yes
    Text left... yes Frequency (Hz)
    Text right... yes F_0 (Hz)
    Axes: 0, 'endTime', 'f0min', 'f0max'
    Text special... 'endTime' left 'avg_pitch' top Times 10 "0" 'avg_pitch'

  #### saving

  Viewport... 0 'picture_width' 0 'spec_height'
  Save as 600-dpi PNG file: pictures_folder$ + "/" + base$ + ".png"
  Erase all
  echo Picture saved in 'pictures_folder$'
  endif

  # clean objects
  selectObject: "Pitch " +base$
  plusObject: "Pitch " +base$
  plusObject: "Pitch " +base$
  plusObject: "Pitch " +base$
  plusObject: "Spectrogram " +base$
  Remove
