using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public class Pipeline<T> : IPipeChain<T>
    {
        private IPipe<T> _root;

        public void Execute(T input)
        {
            if(_root != null && input != null)
                _root.Execute(input);
        }

        public IPipeChain<T> Register(IPipe<T> filter)
        {
            if (_root == null) _root = filter;
            else _root.Register(filter);
            return this;
        }
    }
}
