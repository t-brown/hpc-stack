help([[
]])

local pkgName    = myModuleName()
local pkgVersion = myModuleVersion()
local pkgNameVer = myModuleFullName()

family("python")

conflict(pkgName)
conflict("python")
conflict("intelpython")

local opt = os.getenv("HPC_OPT") or os.getenv("OPT") or "/opt/modules"

local mpath = pathJoin(opt,"modulefiles/python",pkgName,pkgVersion)
prepend_path("MODULEPATH", mpath)

local base = pathJoin(opt,"core",pkgName,pkgVersion)

pushenv("CONDA_ENVS_PATH", pathJoin(base,"envs"))
pushenv("CONDA_PKGS_PATH", pathJoin(base,"pkgs"))

-- These are conda functions defined in conda.sh
local funcs = "conda __conda_activate __conda_hashr __conda_reactivate __add_sys_prefix_to_path"

-- Line #: What does it do?
-- 1: source conda.sh from the installation path
-- 2: export conda functions
local load_cmd = "source " .. pathJoin(base, "etc/profile.d/conda.sh") .. "; \
export -f " .. funcs

-- Line #: What does it do?
-- 1: deactivate all conda envs
-- 2: unset the conda funcs
-- 3: define local variable prefix as path to Miniconda installation
-- 4: remove from PATH all paths to $prefix
-- 5: unset CONDA_ env. variables that are set via sourcing conda.sh
-- 6: unset previously set variable $prefix
local unload_cmd="for i in $(seq ${CONDA_SHLVL:=0}); do conda deactivate; done; \
unset -f " .. funcs .. "; \
prefix=" .. base .. "; \
export PATH=$(echo ${PATH} | tr ':' '\n'  | grep . | grep -v $prefix | tr '\n' ':' | sed 's/:$//'); \
unset $(env | grep CONDA | grep -ev 'CONDA_ENVS_PATH|CONDA_PKGS_PATH' | cut -d= -f1)"

-- source conda on load, deactivate on unload
if (mode() == "load") then
  execute{cmd=load_cmd, modeA={"load"}}
else
  if (mode() == "unload") then
    execute{cmd=unload_cmd, modeA={"unload"}}
  end
end

whatis("Name: ".. pkgName)
whatis("Version: " .. pkgVersion)
whatis("Category: Python")
whatis("Description: Miniconda3 Family")
