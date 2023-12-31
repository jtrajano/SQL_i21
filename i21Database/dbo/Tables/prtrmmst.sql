﻿CREATE TABLE [dbo].[prtrmmst] (
    [prtrm_code]        CHAR (2)    NOT NULL,
    [prtrm_desc]        CHAR (25)   NULL,
    [prtrm_user_id]     CHAR (16)   NULL,
    [prtrm_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prtrmmst] PRIMARY KEY NONCLUSTERED ([prtrm_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprtrmmst0]
    ON [dbo].[prtrmmst]([prtrm_code] ASC);

