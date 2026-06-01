{ ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };

  services.blueman = {
    enable = true;
    withApplet = false; # TODO: temp fix, remove this line when bug is fixed
  };
}