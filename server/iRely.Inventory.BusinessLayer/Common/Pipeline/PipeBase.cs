using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.BusinessLayer
{
    public abstract class PipeBase<T> : IPipe<T>
    {
        private IPipe<T> _next;
        protected abstract T Process(T input);

        public T Execute(T input)
        {
            T val = Process(input);
            if (_next != null) val = _next.Execute(val);
            return val;
        }

        public void Register(IPipe<T> pipe)
        {
            if (_next == null) _next = pipe;
            else _next.Register(pipe);
        }
    }
}
