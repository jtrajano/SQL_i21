CREATE TABLE [dbo].[coefcmst] (
    [coefc_co]               CHAR (2)    NOT NULL,
    [coefc_from_name]        CHAR (25)   NULL,
    [coefc_from_email]       CHAR (64)   NULL,
    [coefc_from_fax]         CHAR (25)   NULL,
    [coefc_notify_email]     CHAR (50)   NULL,
    [coefc_notify_type]      CHAR (5)    NULL,
    [coefc_read_receipt]     CHAR (1)    NULL,
    [coefc_delivery_receipt] CHAR (1)    NULL,
    [coefc_edist_path]       CHAR (25)   NULL,
    [coefc_req_no]           SMALLINT    NULL,
    [coefc_timestamp]        CHAR (19)   NULL,
    [coefc_user_id]          CHAR (16)   NULL,
    [coefc_user_rev_dt]      INT         NULL,
    [A4GLIdentity]           NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_coefcmst] PRIMARY KEY NONCLUSTERED ([coefc_co] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icoefcmst0]
    ON [dbo].[coefcmst]([coefc_co] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[coefcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[coefcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[coefcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[coefcmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[coefcmst] TO PUBLIC
    AS [dbo];

