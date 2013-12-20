CREATE VIEW [dbo].[vwapivcmst]  
AS  
SELECT  
 vwivc_vnd_no = apivc_vnd_no  
, vwivc_ivc_no = apivc_ivc_no  
, vwivc_status_ind = apivc_status_ind  
, vwivc_cbk_no = apivc_cbk_no  
, vwivc_chk_no = apivc_chk_no  
, vwivc_trans_type = apivc_trans_type  
, vwivc_pay_ind = apivc_pay_ind  
, vwivc_ap_audit_no = apivc_ap_audit_no  
, vwivc_pur_ord_no = apivc_pur_ord_no  
, vwivc_po_rcpt_seq = apivc_po_rcpt_seq  
, vwivc_ivc_rev_dt = apivc_ivc_rev_dt  
, vwivc_disc_rev_dt = apivc_disc_rev_dt  
, vwivc_due_rev_dt = apivc_due_rev_dt  
, vwivc_chk_rev_dt = apivc_chk_rev_dt  
, vwivc_gl_rev_dt = apivc_gl_rev_dt  
, vwivc_orig_amt = apivc_orig_amt  
, vwivc_disc_avail = apivc_disc_avail  
, vwivc_disc_taken = apivc_disc_taken  
, vwivc_wthhld_amt = apivc_wthhld_amt  
, vwivc_net_amt = apivc_net_amt  
, vwivc_1099_amt = apivc_1099_amt  
, vwivc_comment = apivc_comment  
, vwivc_adv_chk_no = apivc_adv_chk_no  
, vwivc_recur_yn = apivc_recur_yn  
, vwivc_currency = apivc_currency  
, vwivc_currency_rt = apivc_currency_rt  
, vwivc_currency_cnt = apivc_currency_cnt  
, vwivc_user_id = apivc_user_id  
, vwivc_user_rev_dt = apivc_user_rev_dt  
, A4GLIdentity = CAST(A4GLIdentity   AS INT)
FROM apivcmst
