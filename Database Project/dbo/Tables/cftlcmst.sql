CREATE TABLE [dbo].[cftlcmst] (
    [cftlc_state]        TINYINT     NOT NULL,
    [cftlc_county]       TINYINT     NOT NULL,
    [cftlc_city]         TINYINT     NOT NULL,
    [cftlc_county_desc]  CHAR (20)   NULL,
    [cftlc_city_desc]    CHAR (20)   NULL,
    [cftlc_tax_auth_id1] CHAR (3)    NULL,
    [cftlc_tax_auth_id2] CHAR (3)    NULL,
    [cftlc_user_id]      CHAR (16)   NULL,
    [cftlc_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cftlcmst] PRIMARY KEY NONCLUSTERED ([cftlc_state] ASC, [cftlc_county] ASC, [cftlc_city] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icftlcmst0]
    ON [dbo].[cftlcmst]([cftlc_state] ASC, [cftlc_county] ASC, [cftlc_city] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cftlcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cftlcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cftlcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cftlcmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cftlcmst] TO PUBLIC
    AS [dbo];

