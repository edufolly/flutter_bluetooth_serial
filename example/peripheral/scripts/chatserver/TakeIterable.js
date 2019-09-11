    
const BaseIterable = require('./BaseIterable.js');

class TakeIterable extends BaseIterable {
    constructor(iterable, count) {
        super();
        this._iterable = iterable;
        this._count = count;
    }

    [Symbol.iterator]() {
        let count = this._count;
        let iterable = this._iterable;
        return function* () {
            let iterator = iterable[Symbol.iterator]();
            while (count--) {
                let result = iterator.next();
                if (result.done) {
                    return;
                }
                else {
                    yield result.value;
                }
            }
            while (true) {
                if (iterator.next().done) {
                    return;
                }
            }
        }();
    }

    get length() {
        if ('length' in this._iterable) {
            return Math.min(this._iterable.length, this._count);
        }
        else {
            return undefined;
        }
    }

    static registerIn(...types) {
        if (types.length == 0) {
            return this.registerIn(global.Array);
        }
        for (let type of types) {
            type.prototype.take = function (count) {
                return new TakeIterable(this, count);
            };
        }
        return TakeIterable;
    }
}

module.exports = TakeIterable;
