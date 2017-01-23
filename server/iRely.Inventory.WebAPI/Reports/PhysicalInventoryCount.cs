using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using DevExpress.XtraReports.UI;

namespace iRely.Inventory.WebApi.Reports
{
    public partial class PhysicalInventoryCount : DevExpress.XtraReports.UI.XtraReport
    {
        public PhysicalInventoryCount()
        {
            InitializeComponent();
        }

        private void valCountByLots_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
        {
            valCountByLots.Visible = false;
            valCountByLots.WidthF = 0;
            valCountByLots.HeightF = 0;

            if (valCountByLots.Text == "False")
            {
                lblLotID.Dispose();
                valueLotID.Dispose();
            }
        }

        private void valCountByPallets_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
        {
            valCountByPallets.Visible = false;
            valCountByPallets.WidthF = 0;
            valCountByPallets.HeightF = 0;

            if (valCountByPallets.Text == "False")
            {
                lblNoOfPallets.Dispose();
                valueNoOfPallets.Dispose();
                lblQtyPerPallet.Dispose();
                valueQtyPerPallet.Dispose();
            }
        }
        private void valScannedCountEntry_BeforePrint(object sender, System.Drawing.Printing.PrintEventArgs e)
        {
            valScannedCountEntry.Visible = false;
            valScannedCountEntry.WidthF = 0;
            valScannedCountEntry.HeightF = 0;

            if (valScannedCountEntry.Text == "False")
            {
                barCodeCountNo.Visible=false;
                lblCountID.Visible = false;
                valueCountNo.Visible = false;
                lblCountID2.Visible = true;
                valueCountNo2.Visible = true;
                lblCountID2.LocationF = new PointF(1478.72F, 150.73F);
                valueCountNo2.LocationF = new PointF(1672.19F, 150.73F);
            }
            else
            {
                barCodeCountNo.Visible = true;
                lblCountID.Visible = true;
                valueCountNo.Visible = true;
                lblCountID2.Visible = false;
                valueCountNo2.Visible = false;
                lblCountID2.LocationF = new PointF(1478.72F, 347.68F);
                valueCountNo2.LocationF = new PointF(1672.19F, 347.68F);
            }
        }
    }
}
