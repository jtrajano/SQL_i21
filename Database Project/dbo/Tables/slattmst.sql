CREATE TABLE [dbo].[slattmst] (
    [slatt_lead_id]       CHAR (10)   NOT NULL,
    [slatt_att_name]      CHAR (30)   NOT NULL,
    [slatt_att_file_name] CHAR (120)  NULL,
    [slatt_att_desc]      CHAR (80)   NULL,
    [slatt_user_id]       CHAR (16)   NULL,
    [slatt_user_rev_dt]   INT         NULL,
    [slatt_user_time]     CHAR (8)    NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slattmst] PRIMARY KEY NONCLUSTERED ([slatt_lead_id] ASC, [slatt_att_name] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Islattmst0]
    ON [dbo].[slattmst]([slatt_lead_id] ASC, [slatt_att_name] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[slattmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[slattmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[slattmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[slattmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[slattmst] TO PUBLIC
    AS [dbo];

