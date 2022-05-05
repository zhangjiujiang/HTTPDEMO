import type { Principal } from '@dfinity/principal';
export interface Proxy { 'getBucket' : () => Promise<Principal> }
export interface _SERVICE extends Proxy {}
