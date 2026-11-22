{ lib, ... }:
{
  options.demo.version = lib.mkOption {
    type = lib.types.str;
    default = "2.1.1";
    description = "Version tag used for all demo application images and OTEL resource attributes.";
  };
}
