CREATE TABLE [dbo].[etimxmst] (
    [etimx_min_item]    CHAR (15)   NOT NULL,
    [etimx_max_item]    CHAR (15)   NOT NULL,
    [etimx_msg_no]      INT         NOT NULL,
    [etimx_user_id]     CHAR (16)   NULL,
    [etimx_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_etimxmst] PRIMARY KEY NONCLUSTERED ([etimx_min_item] ASC, [etimx_max_item] ASC, [etimx_msg_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ietimxmst0]
    ON [dbo].[etimxmst]([etimx_min_item] ASC, [etimx_max_item] ASC, [etimx_msg_no] ASC);

