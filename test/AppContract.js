// @ts-nocheck
const AppContract = artifacts.require('App');
const chai = require('chai');
const chaiAsPromised = require("chai-as-promised");
const nilAddress = "0x0000000000000000000000000000000000000000";
const username1 = "rxx", dataHash1 = "3e19a674b9494bbe4798f29b506ff25b", 
      username2 = "rajat", dataHash2 = "d2ff3b88d34705e01d150c21fa7bde07";

let appContract, account1, options;

chai.use(chaiAsPromised);
chai.should();

contract('AppContract', (accounts) => {
   describe('Contract deployment', function () {
      this.beforeAll(async function () {
         appContract = await AppContract.deployed();

         [account1] = accounts;
         options = {
            from: account1
         };
      });

      describe("Profile creation", function () {
         it("Should not accept invalid username", async () => {
            await appContract.createProfile('', dataHash1, options).should.be.rejectedWith(Error); // not allowed empty string
            await appContract.createProfile('xy', dataHash1, options).should.be.rejectedWith(Error); // not allowed less than 2 chars
            await appContract.createProfile(
               'ad21599c838ca16a2a5d42cc7df464aef7aee3d7f5a26bf16bb8cc2fc549ce01',  // not allowed more than 28 chars
               dataHash1,
               options
            ).should.be.rejectedWith(Error);
         });

         it("Should not accept invalid dataHash", async() => {
            await appContract.createProfile(username1, '', options).should.be.rejectedWith(Error);
         });

         it("Should allow to create profile", async () => {
            await appContract.createProfile(username1, dataHash1, options);
         });

         it ("Should not accept unavailable username", async () => {
            await appContract.createProfile(username1, dataHash1).should.be.rejectedWith(Error);
         });
         
         it ("Should not allow to create multiple profiles", async () => {
            await appContract.createProfile(username2, dataHash1).should.be.rejectedWith(Error);
         });
      });

      describe("Profile common checks", function () {
         it("Should have a valid address", async () => {
            assert.equal(await appContract.addressOf(username1), account1);
            assert.equal(
               (await appContract.getProfileByUsername(username1))['username'],
               username1
            );
         });
         
         it("Should have a valid username", async () => {
            assert.equal(await appContract.usernameOf(account1), username1);
            assert.equal(
               (await appContract.getProfileByAddress(account1))['username'], 
               username1
            );
         });
         
         it("Should have a valid dataHash", async () => {
            assert.equal(await appContract.getProfileHashByUsername(username1), dataHash1);
            assert.equal(
               (await appContract.getProfileByAddress(account1))['dataHash'], 
               dataHash1
            );
         });
      });

      describe("Profile mutations", function () {
         it("Should not allow to set invalid dataHash", async () => {
            await appContract.changeProfileHash('').should.be.rejectedWith(Error);
         });

         it("Should allow to change dataHash", async () => {
            await appContract.changeProfileHash(dataHash2);
            assert.equal(await appContract.getProfileHashByUsername(username1), dataHash2);
         });

         it("Should not allow to set unavailable username", async () => {
            await appContract.changeUsername(username1).should.be.rejectedWith(Error);
         });
         
         it("Should not allow to set empty username", async () => {
            await appContract.changeUsername('').should.be.rejectedWith(Error);
            await appContract.changeUsername('xy').should.be.rejectedWith(Error);
            await appContract.changeUsername(
               'ad21599c838ca16a2a5d42cc7df464aef7aee3d7f5a26bf16bb8cc2fc549ce01'
            ).should.be.rejectedWith(Error);
         });
         
         it("should allow to change username", async () => {
            await appContract.changeUsername(username2);
   
            assert.equal(await appContract.addressOf(username2), account1);
            assert.equal(await appContract.addressOf(username1), nilAddress);
         });
      });

      describe("Profile deletion", function () {
         it("Should allow to delete profile", async () => {
            await appContract.deleteProfile();
         });

         it("Should removed from system", async () => {
            assert.equal(await appContract.addressOf(username1), nilAddress);
         });
      });
   });
});
