let
  jupyter = import (builtins.fetchGit {
    url = https://github.com/tweag/jupyterWith;
    rev = "";
  }) {};

  iPython = jupyter.kernels.iPythonWith {
    name = "python";
    packages = p: with p; [ numpy matplotlib ];
  };

  iHaskell = jupyter.kernels.iHaskellWith {
    name = "haskell";
    packages = p: with p; [ hvega formatting matrix process JuicyPixels repa repa-io repa-algorithms];
  };

  jupyterEnvironment =
    jupyter.jupyterlabWith {
      kernels = [ iPython iHaskell ];
    };
in
  jupyterEnvironment.env
