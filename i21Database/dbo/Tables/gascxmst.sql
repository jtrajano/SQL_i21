﻿CREATE TABLE [dbo].[gascxmst] (
    [gascx_cus_no]      CHAR (10)   NOT NULL,
    [gascx_rec_type]    CHAR (1)    NOT NULL,
    [gascx_data]        CHAR (16)   NOT NULL,
    [gascx_user_id]     CHAR (16)   NULL,
    [gascx_user_rev_dt] CHAR (8)    NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gascxmst] PRIMARY KEY NONCLUSTERED ([gascx_cus_no] ASC, [gascx_rec_type] ASC, [gascx_data] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igascxmst0]
    ON [dbo].[gascxmst]([gascx_cus_no] ASC, [gascx_rec_type] ASC, [gascx_data] ASC);

