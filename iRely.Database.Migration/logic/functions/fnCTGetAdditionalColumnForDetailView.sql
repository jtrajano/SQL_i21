--liquibase formatted sql

-- changeset Von:fnCTGetAdditionalColumnForDetailView.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnCTGetAdditionalColumnForDetailView]
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



