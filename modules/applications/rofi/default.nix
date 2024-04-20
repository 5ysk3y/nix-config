{ config, pkgs, lib, inputs, ... }: {

    options = with lib; {
      applications = {
          rofi = mkEnableOption "Enables rofi with custom configs";
      };
    };

    config = with lib; mkIf config.applications.rofi {
        programs = {
            rofi = {
                enable = true;
                package = pkgs.rofi-wayland;
            }; # End Rofi
        }; # End programs

        home.file."${config.xdg.configHome}/rofi/config.rasi".text = ''
        * {
            /* Dracula theme colour palette */
            drac-bgd: #282a36;
            drac-cur: #44475a;
            drac-fgd: #f8f8f2;
            drac-cmt: #6272a4;
            drac-cya: #8be9fd;
            drac-grn: #50fa7b;
            drac-ora: #ffb86c;
            drac-pnk: #ff79c6;
            drac-pur: #bd93f9;
            drac-red: #ff5555;
            drac-yel: #f1fa8c;

            font: "Tamzen Bold 12";

            foreground: @drac-fgd;
            background-color: @drac-bgd;
            active-background: @drac-pnk;
            urgent-background: @drac-red;
            urgent-foreground: @drac-bgd;

            selected-background: @active-background;
            selected-urgent-background: @urgent-background;
            selected-active-background: @active-background;
            separatorcolor: @active-background;
            bordercolor: #6272a4;
        }

        #window {
            background-color: @background-color;
            border:           3;
            border-radius: 6;
            border-color: @bordercolor;
            padding:          5;
        }
        #mainbox {
            border:  0;
            padding: 5;
        }
        #message {
            border:       1px dash 0px 0px ;
            border-color: @separatorcolor;
            padding:      1px ;
        }
        #textbox {
            text-color: @foreground;
        }
        #listview {
            fixed-height: 0;
            border:       2px dash 0px 0px ;
            border-color: @bordercolor;
            spacing:      2px ;
            scrollbar:    false;
            padding:      2px 0px 0px ;
        }
        #element {
            border:  0;
            padding: 1px ;
        }
        #element.normal.normal {
            background-color: @background-color;
            text-color:       @foreground;
        }
        #element.normal.urgent {
            background-color: @urgent-background;
            text-color:       @urgent-foreground;
        }
        #element.normal.active {
            background-color: @active-background;
            text-color:       @background-color;
        }
        #element.selected.normal {
            background-color: @selected-background;
            text-color:       @foreground;
        }
        #element.selected.urgent {
            background-color: @selected-urgent-background;
            text-color:       @foreground;
        }
        #element.selected.active {
            background-color: @selected-active-background;
            text-color:       @background-color;
        }
        #element.alternate.normal {
            background-color: @background-color;
            text-color:       @foreground;
        }
        #element.alternate.urgent {
            background-color: @urgent-background;
            text-color:       @foreground;
        }
        #element.alternate.active {
            background-color: @active-background;
            text-color:       @foreground;
        }
        #scrollbar {
            width:        2px ;
            border:       0;
            handle-width: 8px ;
            padding:      0;
        }
        #sidebar {
            border:       2px dash 0px 0px ;
            border-color: @separatorcolor;
        }
        #button.selected {
            background-color: @selected-background;
            text-color:       @foreground;
        }
        #inputbar {
            spacing:    0;
            text-color: @foreground;
            padding:    1px ;
        }
        #case-indicator {
            spacing:    0;
            text-color: @foreground;
        }
        #entry {
            spacing:    0;
            text-color: @drac-cya;
        }
        #prompt {
            spacing:    0;
            text-color: @drac-grn;
        }
        #inputbar {
            children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];
        }
        #textbox-prompt-colon {
            expand:     false;
            str:        ":";
            margin:     0px 0.3em 0em 0em ;
            text-color: @drac-grn;
        }
        element-text, element-icon {
            background-color: inherit;
            text-color: inherit;
        }
        '';
    }; # END CONFIG
}
