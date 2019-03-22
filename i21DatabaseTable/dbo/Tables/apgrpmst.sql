CREATE TABLE [dbo].[apgrpmst] (
    [apgrp_grp_no]      CHAR (2)    NOT NULL,
    [apgrp_comment_1]   CHAR (40)   NULL,
    [apgrp_comment_2]   CHAR (40)   NULL,
    [apgrp_comment_3]   CHAR (40)   NULL,
    [apgrp_user_id]     CHAR (16)   NULL,
    [apgrp_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apgrpmst] PRIMARY KEY NONCLUSTERED ([apgrp_grp_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iapgrpmst0]
    ON [dbo].[apgrpmst]([apgrp_grp_no] ASC);

