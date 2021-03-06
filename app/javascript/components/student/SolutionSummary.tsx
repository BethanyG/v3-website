import React, { useEffect } from 'react'
import { Header } from './solution-summary/Header'
import { IterationLink } from './solution-summary/IterationLink'
import { CommunitySolutions } from './solution-summary/CommunitySolutions'
import { Mentoring } from './solution-summary/Mentoring'
import { Nudge } from './solution-summary/Nudge'
import { Loading, ProminentLink } from '../common'
import { SolutionChannel } from '../../channels/solutionChannel'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { queryCache } from 'react-query'
import { Iteration, MentorDiscussion } from '../types'

export type SolutionSummaryLinks = {
  testsPassLocallyArticle: string
  allIterations: string
  communitySolutions: string
  learnMoreAboutMentoringArticle: string
  mentoringInfo: string
  completeExercise: string
  shareMentoring: string
  requestMentoring: string
  pendingMentorRequest: string
  inProgressDiscussion?: string
}

export type SolutionSummaryRequest = {
  endpoint: string
  options: {
    initialData: {
      iterations: readonly Iteration[]
    }
  }
}

export type SolutionSummarySolution = {
  id: string
  hasMentorDiscussionInProgress: boolean
  hasMentorRequestPending: boolean
  completedAt?: string
}

export const SolutionSummary = ({
  solution,
  discussions,
  request,
  isConceptExercise,
  links,
}: {
  solution: SolutionSummarySolution
  discussions: readonly MentorDiscussion[]
  request: SolutionSummaryRequest
  isConceptExercise: boolean
  links: SolutionSummaryLinks
}): JSX.Element | null => {
  const isMountedRef = useIsMounted()
  const CACHE_KEY = `solution-${solution.id}-summary`
  const { resolvedData } = usePaginatedRequestQuery<{
    iterations: Iteration[]
  }>(CACHE_KEY, request, isMountedRef)

  useEffect(() => {
    const solutionChannel = new SolutionChannel(
      { id: solution.id },
      (response) => {
        queryCache.setQueryData(CACHE_KEY, response)
      }
    )

    return () => {
      solutionChannel.disconnect()
    }
  }, [CACHE_KEY, solution])

  if (status === 'loading') {
    return <Loading />
  }

  if (!resolvedData) {
    return null
  }

  const latestIteration =
    resolvedData.iterations[resolvedData.iterations.length - 1]

  return (
    <>
      {solution.completedAt ? null : (
        <Nudge
          hasMentorDiscussionInProgress={solution.hasMentorDiscussionInProgress}
          discussions={discussions}
          hasMentorRequestPending={solution.hasMentorRequestPending}
          iteration={latestIteration}
          isConceptExercise={isConceptExercise}
          links={links}
        />
      )}
      <section className="latest-iteration">
        <Header
          iteration={latestIteration}
          isConceptExercise={isConceptExercise}
          links={links}
        />
        <IterationLink iteration={latestIteration} />
        <ProminentLink
          link={links.allIterations}
          text="See all of your iterations"
        />
        <div className="next-steps">
          <CommunitySolutions link={links.communitySolutions} />
          <Mentoring
            hasMentorDiscussionInProgress={
              solution.hasMentorDiscussionInProgress
            }
            hasMentorRequestPending={solution.hasMentorRequestPending}
            discussions={discussions}
            links={links}
          />
        </div>
      </section>
    </>
  )
}
