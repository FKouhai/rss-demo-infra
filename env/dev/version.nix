{ lib, ... }:
{
  options.demo.version = lib.mkOption {
    type = lib.types.str;
    default = "1.0.4";
    description = "Version tag used for all demo application images and OTEL resource attributes.";
  };
}
