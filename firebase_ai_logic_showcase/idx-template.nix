{ pkgs, projectId, bootstrapJs, ... }:
{
  bootstrap = ''
    cp -rf ${./.} "$out/"
    chmod -R +w "$out"
    echo 'bootstrapJs was set to: ${bootstrapJs}'
    # Apply project ID to configs
    if [ -z '${bootstrapJs}' ] || [ '${bootstrapJs}' = 'false' ]
    then
      sed -e 's/<project-id>/${projectId}/' ${.idx/dev.nix} > "$out/.idx/dev.nix"
    else
      sed -e 's/<project-id>/${projectId}/' ${.idx/dev.nix} | sed -e 's/terraform init/# terraform init/' | sed -e 's/terraform apply/# terraform apply/' > "$out/.idx/dev.nix"
      echo '${bootstrapJs}' > "$out/web/bootstrap.js"
      echo '{"projects":{"default":"${projectId}"}}' > "$out/.firebaserc"
    fi
    # Remove the template files themselves and any connection to the template's
    # Git repository
    rm -rf "$out/.git" "$out/idx-template".{nix,json} "$out/node_modules"
  '';
}
