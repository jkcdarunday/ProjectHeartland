use iron::prelude::*;
use iron::status;
pub struct Enlisted;
impl Enlisted{
    pub fn get(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }

    pub fn put(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }

    pub fn del(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }
}

pub struct Waitlist;
impl Waitlist{
    pub fn get(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }

    pub fn put(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }

    pub fn del(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }
}

pub struct Auth;
impl Auth{
    pub fn post(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }

    pub fn del(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }
}

pub struct Subject;
impl Subject{
    pub fn get(_: &mut Request) -> IronResult<Response> {
        Ok(Response::with((status::NotFound, "unimplemented")))
    }
}
