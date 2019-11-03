
class BaseIterable {
    get iterator() {
        return this[Symbol.iterator]();
    }

    static registerIn(...types) {
        if (types.length == 0) {
            return this.registerIn(global.Array);
        }
        for (let type of types) {
            Object.defineProperty(type.prototype, 'iterator', {
                get: function() {
                    return this[Symbol.iterator]();
                }
            });
        }
        return BaseIterable;
    }
}

module.exports = BaseIterable;
