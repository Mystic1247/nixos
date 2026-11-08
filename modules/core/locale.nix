# Time zone. A default rather than a fixed value, so a host that lives
# elsewhere can override it with a plain `time.timeZone = "...";`.

{ lib, ... }:

{
  time.timeZone = lib.mkDefault "Asia/Singapore";
}
