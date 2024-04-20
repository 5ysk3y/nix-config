{ lib
, python3Packages
, fetchFromGitHub
, fetchpatch
, substituteAll
, copyDesktopItems
, writeText
, makeDesktopItem
, wrapGAppsHook
, xvfb-run
, qt6
, fontconfig
}:

python3Packages.buildPythonApplication rec {
  pname = "streamdeck-ui";
  version = "4.1.1";

  src = fetchFromGitHub {
    repo = "streamdeck-linux-gui";
    owner = "streamdeck-linux-gui";
    rev = "v${version}";
    sha256 = "sha256-hz6YMV4ntBwFPFYx6wsHdAOs1bi9NagkxD4UKV6N46c=";
  };

  patches = [
    # nixpkgs has a newer pillow version
    #./update-pillow.patch
    ./fix-metadata.patch

    # upstream forgot to bump the project version
    (fetchpatch {
      name = "bump-version.patch";
      url = "https://github.com/streamdeck-linux-gui/streamdeck-linux-gui/commit/836e748996d94d119e135754d86c08ef284516e2.patch";
      sha256 = "sha256-UEBSxfgImQgJsSWxOX+5T5J82niIvuW3Upuaa9ZcwBU=";
    })

    # fix path to fc-list
    (substituteAll {
      src = ./fix-fc-list.patch;
      fclist = "${fontconfig}/bin/fc-list";
    })
  ];

  desktopItems = let
    common = {
      name = "streamdeck-ui";
      desktopName = "Stream Deck UI";
      icon = "streamdeck-ui";
      exec = "streamdeck";
      comment = "UI for the Elgato Stream Deck";
      categories = [ "Utility" ];
    };
  in builtins.map makeDesktopItem [
    common
    (common // {
      name = "${common.name}-noui";
      exec = "${common.exec} --no-ui";
      noDisplay = true;
    })
  ];

  postInstall =
    let
      udevRules = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", TAG+="uaccess"
      '';
    in
      ''
        mkdir -p $out/lib/systemd/user
        substitute scripts/streamdeck.service $out/lib/systemd/user/streamdeck.service \
          --replace '<path to streamdeck>' $out/bin/streamdeck

        mkdir -p "$out/etc/udev/rules.d"
        cp ${writeText "70-streamdeck.rules" udevRules} $out/etc/udev/rules.d/70-streamdeck.rules

        mkdir -p "$out/share/pixmaps"
        cp streamdeck_ui/logo.png $out/share/pixmaps/streamdeck-ui.png
      '';

  dontWrapQtApps = true;
  dontWrapGApps = true;
  makeWrapperArgs = [ "\${qtWrapperArgs[@]}" "\${gappsWrapperArgs[@]}"];

  format = "pyproject";

  nativeBuildInputs = [
    python3Packages.poetry-core
    copyDesktopItems
    qt6.wrapQtAppsHook
    wrapGAppsHook
  ];

  propagatedBuildInputs = with python3Packages; [
    setuptools
    filetype
    cairosvg
    importlib-metadata
    pillow
    pynput
    pyside6
    streamdeck
    xlib
  ] ++ lib.optionals stdenv.isLinux [
    qt6.qtwayland
  ];

  nativeCheckInputs = [
    xvfb-run
    python3Packages.pytest
    python3Packages.pytest-mock
    python3Packages.pytest-qt
  ];

  checkPhase = ''
    export HOME=$(pwd)
    xvfb-run pytest tests
  '';

  meta = with lib; {
    description = "Linux compatible UI for the Elgato Stream Deck";
    homepage = "https://streamdeck-linux-gui.github.io/streamdeck-linux-gui/";
    license = licenses.mit;
    mainProgram = "streamdeck";
    maintainers = with maintainers; [ majiir ];
  };
}
