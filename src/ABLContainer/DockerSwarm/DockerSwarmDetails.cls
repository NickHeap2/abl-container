USING Progress.Lang.*.
USING ABLContainer.DockerSwarm.* FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ABLContainer.DockerSwarm.DockerSwarmDetails INHERITS Progress.Lang.Object:
  DEFINE PUBLIC PROPERTY Node AS Node NO-UNDO
  GET.
  SET.
  DEFINE PUBLIC PROPERTY Service AS Service NO-UNDO
  GET.
  SET.
  DEFINE PUBLIC PROPERTY Task AS Task NO-UNDO
  GET.
  SET.
END CLASS.
