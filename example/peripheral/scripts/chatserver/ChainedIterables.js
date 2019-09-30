
const BaseIterable = require('./BaseIterable.js');

class ChainedIterables extends BaseIterable {
    constructor(iterables) {
        super();
        this._iterables = iterables;
    }

    [Symbol.iterator]() {
        const iterables = this._iterables;
        return function* () {
            for (const iterable of iterables) {
                let iterator = iterable[Symbol.iterator]();
                while (true) {
                    const result = iterator.next();
                    if (result.done) {
                        break;
                    }
                    yield result.value
                }
            }
        }();
    }

    get length() {
        let sum = 0;
        for (const iterable of this._iterables) {
            if (!('length' in iterable)) {
                return undefined;
            }
            sum += iterable.length;
        }
        return sum;
    }

    chain(...others) {
        return new ChainedIterables(this._iterables.concat([...others]));
    }

    static registerIn(...types) {
        if (types.length == 0) {
            return this.registerIn(global.Array);
        }
        for (let type of types) {
            type.prototype.chain = function (...others) {
                return new ChainedIterables([this, ...others])
            };
        }
        return ChainedIterables;
    }
}

module.exports = ChainedIterables;
