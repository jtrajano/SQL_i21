﻿CREATE TABLE [dbo].[sltypmst] (
    [sltyp_id]          CHAR (1)    NOT NULL,
    [sltyp_desc]        CHAR (20)   NULL,
    [sltyp_user_id]     CHAR (16)   NULL,
    [sltyp_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sltypmst] PRIMARY KEY NONCLUSTERED ([sltyp_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isltypmst0]
    ON [dbo].[sltypmst]([sltyp_id] ASC);

