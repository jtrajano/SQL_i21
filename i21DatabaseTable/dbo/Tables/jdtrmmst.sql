CREATE TABLE [dbo].[jdtrmmst] (
    [jdtrm_merchant_no]   CHAR (8)    NOT NULL,
    [jdtrm_store]         CHAR (4)    NOT NULL,
    [jdtrm_terminal]      CHAR (3)    NOT NULL,
    [jdtrm_terminal_name] CHAR (50)   NULL,
    [jdtrm_timestamp]     CHAR (25)   NULL,
    [jdtrm_user_id]       CHAR (16)   NULL,
    [jdtrm_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_jdtrmmst] PRIMARY KEY NONCLUSTERED ([jdtrm_merchant_no] ASC, [jdtrm_store] ASC, [jdtrm_terminal] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ijdtrmmst0]
    ON [dbo].[jdtrmmst]([jdtrm_merchant_no] ASC, [jdtrm_store] ASC, [jdtrm_terminal] ASC);

