CREATE FUNCTION [dbo].[fnCTGetAdditionalColumnForDetailView]
(
  @intContractDetailId  INT
)

RETURNS TABLE as RETURN
select
  *
from
  vyuCTGetAdditionalColumnForDetailView
where
  intContractDetailId = @intContractDetailId