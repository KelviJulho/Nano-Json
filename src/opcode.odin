#+feature dynamic-literals

package src

Opecodes := map[u8]Types{
    0 = .Nil,
    1 = .Boolean,
    2 = .Integer,
    3 = .Float,
    4 = .String,
    5 = .Array,
    6 = .Object,
}