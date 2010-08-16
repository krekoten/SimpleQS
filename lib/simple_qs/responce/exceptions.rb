module SimpleQS
  class Responce

    class Error < StandardError; end

    class AccessDeniedError                            < Error; end
    class AuthFailureError                            < Error; end
    class AWSSimpleQueueServiceInternalError          < Error; end
    class AWSSimpleQueueServiceNonExistentQueueError  < Error; end
    class AWSSimpleQueueServiceQueueDeletedRecently    < Error; end
    class AWSSimpleQueueServiceQueueNameExists        < Error; end
    class ConflictingQueryParameterError              < Error; end
    class InvalidParameterValueError                  < Error; end
    class InternalError                                < Error; end
    class InvalidAccessKeyIdError                      < Error; end
    class InvalidActionError                          < Error; end
    class InvalidAddressError                          < Error; end
    class InvalidHttpRequestError                      < Error; end
    class InvalidParameterCombinationError            < Error; end
    class InvalidParameterValueError                  < Error; end
    class InvalidQueryParameterError                  < Error; end
    class InvalidRequestError                          < Error; end
    class InvalidSecurityError                        < Error; end
    class InvalidSecurityTokenError                    < Error; end
    class MalformedVersionError                        < Error; end
    class MissingClientTokenIdError                    < Error; end
    class MissingCredentialsError                      < Error; end
    class MissingParameterError                        < Error; end
    class NoSuchVersionError                          < Error; end
    class NotAuthorizedToUseVersionError              < Error; end
    class OptInRequiredError                          < Error; end
    class RequestExpiredError                          < Error; end
    class RequestThrottledError                        < Error; end
    class ServiceUnavailableError                      < Error; end
    class SignatureDoesNotMatchError                  < Error; end
    class X509ParseError                              < Error; end
  end
end
