﻿CREATE TABLE [dbo].[slaremst] (
    [slare_id]          CHAR (4)    NOT NULL,
    [slare_desc]        CHAR (20)   NULL,
    [slare_user_id]     CHAR (16)   NULL,
    [slare_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slaremst] PRIMARY KEY NONCLUSTERED ([slare_id] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Islaremst0]
    ON [dbo].[slaremst]([slare_id] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[slaremst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[slaremst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[slaremst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[slaremst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[slaremst] TO PUBLIC
    AS [dbo];

