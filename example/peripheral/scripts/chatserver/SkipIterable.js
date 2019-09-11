
const BaseIterable = require('./BaseIterable.js');

class SkipIterable extends BaseIterable {
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
                if (iterator.next().done) {
                    return;
                }
            }
            while (true) {
                let result = iterator.next();
                if (result.done) {
                    break;
                }
                else {
                    yield result.value;
                }
            }
        }();
    }

    get length() {
        if ('length' in this._iterable) {
            return Math.max(this._iterable.length - this._count, 0);
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
            type.prototype.skip = function (count) {
                return new SkipIterable(this, count);
            };
        }
        return SkipIterable;
    }
}

module.exports = SkipIterable;
