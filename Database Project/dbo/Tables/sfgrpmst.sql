CREATE TABLE [dbo].[sfgrpmst] (
    [sfgrp_cus_no]       CHAR (10)      NOT NULL,
    [sfgrp_grp_id]       CHAR (14)      NOT NULL,
    [sfgrp_desc]         CHAR (30)      NULL,
    [sfgrp_gender_cd]    CHAR (1)       NULL,
    [sfgrp_animal_cd]    CHAR (1)       NULL,
    [sfgrp_farm_id]      CHAR (10)      NULL,
    [sfgrp_barn_id]      CHAR (15)      NULL,
    [sfgrp_start_wgt]    DECIMAL (7, 3) NULL,
    [sfgrp_start_cst]    DECIMAL (7, 2) NULL,
    [sfgrp_start_rev_dt] INT            NULL,
    [sfgrp_end_rev_dt]   INT            NULL,
    [sfgrp_active_ynt]   CHAR (1)       NULL,
    [sfgrp_current_head] INT            NULL,
    [sfgrp_stg_id]       CHAR (10)      NULL,
    [sfgrp_user_id]      CHAR (16)      NULL,
    [sfgrp_user_rev_dt]  INT            NULL,
    [A4GLIdentity]       NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sfgrpmst] PRIMARY KEY NONCLUSTERED ([sfgrp_cus_no] ASC, [sfgrp_grp_id] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Isfgrpmst0]
    ON [dbo].[sfgrpmst]([sfgrp_cus_no] ASC, [sfgrp_grp_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Isfgrpmst1]
    ON [dbo].[sfgrpmst]([sfgrp_grp_id] ASC, [sfgrp_cus_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sfgrpmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sfgrpmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sfgrpmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sfgrpmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[sfgrpmst] TO PUBLIC
    AS [dbo];

