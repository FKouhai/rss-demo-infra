{ lib, ... }:
{
  options.demo.version = lib.mkOption {
    type = lib.types.str;
    default = "2.0.0-rc-3";
    description = "Version tag used for all demo application images and OTEL resource attributes.";
  };
}
