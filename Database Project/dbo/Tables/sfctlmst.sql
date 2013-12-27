CREATE TABLE [dbo].[sfctlmst] (
    [sfctl_key]            TINYINT     NOT NULL,
    [sfctl_password]       CHAR (8)    NULL,
    [sfctl_purge_rev_dt]   INT         NULL,
    [sfctl_gender_cd_1]    CHAR (1)    NULL,
    [sfctl_gender_cd_2]    CHAR (1)    NULL,
    [sfctl_gender_cd_3]    CHAR (1)    NULL,
    [sfctl_gender_cd_4]    CHAR (1)    NULL,
    [sfctl_gender_cd_5]    CHAR (1)    NULL,
    [sfctl_gender_desc_1]  CHAR (10)   NULL,
    [sfctl_gender_desc_2]  CHAR (10)   NULL,
    [sfctl_gender_desc_3]  CHAR (10)   NULL,
    [sfctl_gender_desc_4]  CHAR (10)   NULL,
    [sfctl_gender_desc_5]  CHAR (10)   NULL,
    [sfctl_animal_cd_1]    CHAR (1)    NULL,
    [sfctl_animal_cd_2]    CHAR (1)    NULL,
    [sfctl_animal_cd_3]    CHAR (1)    NULL,
    [sfctl_animal_cd_4]    CHAR (1)    NULL,
    [sfctl_animal_cd_5]    CHAR (1)    NULL,
    [sfctl_animal_cd_6]    CHAR (1)    NULL,
    [sfctl_animal_cd_7]    CHAR (1)    NULL,
    [sfctl_animal_cd_8]    CHAR (1)    NULL,
    [sfctl_animal_cd_9]    CHAR (1)    NULL,
    [sfctl_animal_cd_10]   CHAR (1)    NULL,
    [sfctl_animal_desc_1]  CHAR (10)   NULL,
    [sfctl_animal_desc_2]  CHAR (10)   NULL,
    [sfctl_animal_desc_3]  CHAR (10)   NULL,
    [sfctl_animal_desc_4]  CHAR (10)   NULL,
    [sfctl_animal_desc_5]  CHAR (10)   NULL,
    [sfctl_animal_desc_6]  CHAR (10)   NULL,
    [sfctl_animal_desc_7]  CHAR (10)   NULL,
    [sfctl_animal_desc_8]  CHAR (10)   NULL,
    [sfctl_animal_desc_9]  CHAR (10)   NULL,
    [sfctl_animal_desc_10] CHAR (10)   NULL,
    [sfctl_dlvy_cls_cd]    CHAR (3)    NULL,
    [sfctl_drug_cls_cd]    CHAR (3)    NULL,
    [sfctl_shrk_itm_no]    CHAR (13)   NULL,
    [sfctl_shrk_cost_used] CHAR (1)    NULL,
    [sfctl_wgt_pt]         CHAR (1)    NULL,
    [sfctl_user_id]        CHAR (16)   NULL,
    [sfctl_user_rev_dt]    INT         NULL,
    [A4GLIdentity]         NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sfctlmst] PRIMARY KEY NONCLUSTERED ([sfctl_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Isfctlmst0]
    ON [dbo].[sfctlmst]([sfctl_key] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sfctlmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[sfctlmst] TO PUBLIC
    AS [dbo];

