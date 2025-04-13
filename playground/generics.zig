const std = @import("std");

// If account is of type A, then when merged it will be of type A.
const AccountTypeA = struct {
    id: u32,
    balance: f64,
};

// If account is of type B, then when merged it will be of type A.
const AccountTypeB = struct {
    id: u32,
    balance: f64,
};

const BankingError = error{ InvalidAccountType, InvalidAccountCombination };

fn mergeAandB(a: AccountTypeA, b: AccountTypeB) AccountTypeA {
    return AccountTypeA{ .id = a.id, .balance = a.balance + b.balance };
}

// generic function that accepts different account types
fn mergeAccounts(comptime T: type, comptime U: type, a: T, b: U) BankingError!AccountTypeA {
    // Check if the account types are compatible
    if (U == AccountTypeA and T == AccountTypeA) {
        return BankingError.InvalidAccountType;
    }
    if (U == AccountTypeB and T == AccountTypeB) {
        return BankingError.InvalidAccountType;
    }

    if (T == AccountTypeA) {
        return mergeAandB(a, b);
    }

    if (U == AccountTypeA) {
        return mergeAandB(b, a);
    }

    return BankingError.InvalidAccountCombination;
}

pub fn main() void {
    const accountA1 = AccountTypeA{
        .id = 1,
        .balance = 100.0,
    };

    const accountB1 = AccountTypeB{
        .id = 2,
        .balance = 200.0,
    };

    // Generic merging based purely on the struct type (no boolean flags or type in the struct)
    const AmergeB = mergeAccounts(AccountTypeA, AccountTypeB, accountA1, accountB1) catch |err| {
        std.debug.print("Error merging accounts: {}\n", .{err});
        return;
    };

    std.debug.print("Account A merged: id={}, balance={d}\n", .{ AmergeB.id, AmergeB.balance });

    // -------------------------------

    const accountA2 = AccountTypeA{
        .id = 4,
        .balance = 400.0,
    };

    const accountB2 = AccountTypeB{
        .id = 3,
        .balance = 300.0,
    };

    const BmergeA = mergeAccounts(AccountTypeB, AccountTypeA, accountB2, accountA2) catch |err| {
        std.debug.print("Error merging accounts: {}\n", .{err});
        return;
    };
    std.debug.print("Account B merged: id={}, balance={d}\n", .{ BmergeA.id, BmergeA.balance });
}
