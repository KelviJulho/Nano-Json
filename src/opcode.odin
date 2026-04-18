#+feature dynamic-literals

package src

Opecodes := map[u8]Types{
    0 = .Nil,
    1 = .Boolean,
    2 = .Number,
    3 = .String,
    4 = .Array,
    5 = .Object,
}