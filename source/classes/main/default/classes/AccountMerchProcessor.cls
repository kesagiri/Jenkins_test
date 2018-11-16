/**
 * Created by RAMukhamadeev on 09.07.2018. sdfsdf
 */

public without sharing class AccountMerchProcessor {
    public static final String MERCH = 'Merch';
    public static final String ACCESS_LEVEL = 'Edit';

    static void touchAccounts(List<AccountMerch__c> accountMerches) {
        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>();
        for (AccountMerch__c currAccountMerch : accountMerches) {
            accountIdToAccountMap.put(currAccountMerch.AccountId__c, new Account(Id = currAccountMerch.AccountId__c));
        }
        update accountIdToAccountMap.values();
    }

    static AccountTeamMember getNewAccountTeamMember(Id accountId, Id userId) {
        return new AccountTeamMember(
                AccountId = accountId,
                UserId = userId,
                TeamMemberRole = MERCH,
                AccountAccessLevel = ACCESS_LEVEL
        );
    }

    static string getKey(AccountTeamMember accountTeamMember) {
        return String.valueOf(accountTeamMember.AccountId) + String.valueOf(accountTeamMember.UserId);
    }

    static string getKey(AccountMerch__c accountMerch) {
        return String.valueOf(accountMerch.AccountId__c) + String.valueOf(accountMerch.OwnerId__c);
    }

    static AccountTeamMember getExistingAccountTeamMember(AccountMerch__c accountMerch, Map<String, Id> accountTeamMemberMap) {
        string key = getKey(accountMerch);
        if (accountTeamMemberMap.containsKey(key)) {
            return new AccountTeamMember(Id = accountTeamMemberMap.get(key));
        } else {
            return null;
        }
    }

    static Map<String, Id> getAccountTeamMemberIdMap(List<AccountMerch__c> accountMerches) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        for (AccountMerch__c currAccountMerch : accountMerches) {
            accountIds.add(currAccountMerch.AccountId__c);
            userIds.add(currAccountMerch.OwnerId__c);
        }

        Map<String, Id> result = new Map<String, Id>();
        for (AccountTeamMember currAccountTeamMember : [
                SELECT Id, UserId, AccountId
                FROM AccountTeamMember
                WHERE AccountId IN :accountIds AND UserId IN :userIds
        ]) {
            result.put(getKey(currAccountTeamMember), currAccountTeamMember.Id);
        }

        return result;
    }

    public static void createNewAccess(List<AccountMerch__c> newAccountMerches) {
        List<AccountTeamMember> teamForInsert = new List<AccountTeamMember>();
        for (AccountMerch__c currAccountMerch : newAccountMerches) {
            teamForInsert.add(getNewAccountTeamMember(currAccountMerch.AccountId__c, currAccountMerch.OwnerId__c));
        }
        if (teamForInsert.size() > 0) {
            insert teamForInsert;
        }

        touchAccounts(newAccountMerches);
    }

    public static void deleteAccess(List<AccountMerch__c> accountMerches) {
        List<AccountTeamMember> teamForDelete = new List<AccountTeamMember>();
        Map<String, Id> accountTeamMemberMap = getAccountTeamMemberIdMap(accountMerches);

        for (AccountMerch__c currAccountMerch : accountMerches) {
            AccountTeamMember accountTeamMember = getExistingAccountTeamMember(currAccountMerch, accountTeamMemberMap);
            if (accountTeamMember != null) {
                teamForDelete.add(accountTeamMember);
            }

        }
        if (teamForDelete.size() > 0) {
            delete teamForDelete;
        }

        touchAccounts(accountMerches);
    }

    public static void editAccess(List<AccountMerch__c> newAccountMerches, Map<Id, AccountMerch__c> oldAccountMerches) {
        List<AccountTeamMember> teamForInsert = new List<AccountTeamMember>();
        List<AccountTeamMember> teamForDelete = new List<AccountTeamMember>();
        List<AccountMerch__c> changedAccountMerches = new List<AccountMerch__c>();
        Map<String, Id> accountTeamMemberMap = getAccountTeamMemberIdMap(newAccountMerches);

        for (AccountMerch__c currAccountMerch : newAccountMerches) {
            AccountMerch__c currOldAccountMerch = oldAccountMerches.get(currAccountMerch.Id);
            if (currAccountMerch.isActive__c != currOldAccountMerch.isActive__c) {
                changedAccountMerches.add(currAccountMerch);
                if (currAccountMerch.isActive__c && !currOldAccountMerch.isActive__c) {
                    teamForInsert.add(getNewAccountTeamMember(currAccountMerch.AccountId__c, currAccountMerch.OwnerId__c));
                } else if (!currAccountMerch.isActive__c && currOldAccountMerch.isActive__c) {
                    AccountTeamMember accountTeamMember = getExistingAccountTeamMember(currAccountMerch, accountTeamMemberMap);
                    if (accountTeamMember != null) {
                        teamForDelete.add(accountTeamMember);
                    }
                }
            }
        }
        if (teamForDelete.size() > 0) {
            delete teamForDelete;
        }
        if (teamForInsert.size() > 0) {
            insert teamForInsert;
        }

        touchAccounts(changedAccountMerches);
    }
}