# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.nodePackages.firebase-tools
    pkgs.jdk21
    pkgs.unzip
  ];
  # Sets environment variables in the workspace
  env = {
    # Enable AppCheck for additional security for critical endpoints.
    # Follow the configuration steps in the README to set up your project.
    # ENABLE_APPCHECK = "TRUE";
    LOCAL_RECOMMENDATION_SERVICE = "http://127.0.0.1:8084";
    GOOGLE_PROJECT = "<project-id>";
    CLOUDSDK_CORE_PROJECT = "<project-id>";
    TF_VAR_project = "<project-id>";
    # Flip to true to help improve Angular
    NG_CLI_ANALYTICS = "false";
    # Quieter Terraform logs
    TF_IN_AUTOMATION = "true";
  };
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
      "hashicorp.terraform"
    ];
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = { 
        installDependencies = "flutter pub get";
        default.openFiles = [
          "README.md"
          "lib/main.dart"
        ];
      };
      # To run something each time the workspace is (re)started, use the `onStart` hook
    };
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = [ "flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT" ];
          manager = "flutter";
        };
        # android = {
        #   command = [ "flutter" "run" "--machine" "-d" "android" "-d" "localhost:5555" ];
        #   manager = "flutter";
        # };
      };
    };
  };
}
