﻿using iRely.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Threading.Tasks;

using iRely.Inventory.Model;
using iRely.Inventory.BusinessLayer;

namespace iRely.Inventory.WebApi
{
    public class ItemController : BaseApiController<tblICItem>
    {
        private IItemBl _bl;

        public ItemController(IItemBl bl)
            : base(bl)
        {
            _bl = bl;
        }

        [HttpGet]
        [ActionName("GetCompactItems")]
        public async Task<HttpResponseMessage> GetCompactItems(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetCompactItems(param));
        }

        [HttpGet]
        [ActionName("GetItemStocks")]
        public async Task<HttpResponseMessage> GetItemStocks(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStocks(param));
        }

        [HttpGet]
        [ActionName("GetItemStockDetails")]
        public async Task<HttpResponseMessage> GetItemStockDetails(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetItemStockDetails(param));
        }

        [HttpGet]
        [ActionName("GetAssemblyItems")]
        public async Task<HttpResponseMessage> GetAssemblyItems(GetParameter param)
        {
            return Request.CreateResponse(HttpStatusCode.OK, await _bl.GetAssemblyItems(param));
        }

    }
}
